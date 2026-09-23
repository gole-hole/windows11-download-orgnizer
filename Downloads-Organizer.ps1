# ============================================================
# RELIABLE WINDOWS DOWNLOADS ORGANIZER
#
# Checks Downloads every 2 seconds.
#
# NEW DOWNLOADS:
#   Images    -> Downloads\Images
#   Music     -> Downloads\Music
#   Videos    -> Downloads\Videos
#   Documents -> Downloads\Documents
#   Archives  -> Downloads\Archives
#   Apps      -> Downloads\Apps
#   Code      -> Downloads\Code
#   Fonts     -> Downloads\Fonts
#   Unknown   -> Downloads\Other
#
# AFTER 48 HOURS:
#   Images    -> Pictures
#   Music     -> Music
#   Videos    -> Videos
#   Documents -> Documents
#
# ============================================================


# ============================================================
# SETTINGS
# ============================================================

$downloads = Join-Path $env:USERPROFILE "Downloads"

$delayHours = 48

$pictures  = [Environment]::GetFolderPath("MyPictures")
$music     = [Environment]::GetFolderPath("MyMusic")
$videos    = [Environment]::GetFolderPath("MyVideos")
$documents = [Environment]::GetFolderPath("MyDocuments")


# ============================================================
# FILE TYPE RULES
# ============================================================

$rules = @{

    "Images" = @(
        ".jpg",".jpeg",".png",".gif",".webp",".bmp",
        ".svg",".ico",".tif",".tiff",".heic",".raw",
        ".cr2",".nef",".arw",".dng"
    )

    "Videos" = @(
        ".mp4",".mkv",".mov",".avi",".wmv",".flv",
        ".webm",".m4v",".3gp",".ts",".vob",
        ".mpeg",".mpg"
    )

    "Music" = @(
        ".mp3",".opus",".flac",".wav",".aac",".ogg",
        ".m4a",".wma",".aiff",".aif",".alac"
    )

    "Documents" = @(
        ".pdf",".docx",".doc",".xlsx",".xls",
        ".pptx",".ppt",".txt",".csv",".odt",
        ".rtf",".md",".epub",".mobi"
    )

    "Archives" = @(
        ".zip",".rar",".7z",".tar",".gz",
        ".bz2",".xz",".iso",".cab"
    )

    "Apps" = @(
        ".exe",".msi",".apk",".dmg",".deb",
        ".rpm",".msix",".appx"
    )

    "Code" = @(
        ".py",".js",".ts",".html",".css",".json",
        ".xml",".sql",".sh",".bat",".cmd",".ps1",
        ".java",".cpp",".c",".h",".cs",".go",
        ".rs",".rb",".php"
    )

    "Fonts" = @(
        ".ttf",".otf",".woff",".woff2"
    )
}


# ============================================================
# 48-HOUR DESTINATIONS
# ============================================================

$permanentFolders = @{
    "Images"    = $pictures
    "Music"     = $music
    "Videos"    = $videos
    "Documents" = $documents
}


# ============================================================
# TEMPORARY DOWNLOAD EXTENSIONS
# ============================================================

$tempExtensions = @(
    ".crdownload",
    ".part",
    ".tmp",
    ".download"
)


# ============================================================
# GET CATEGORY
# ============================================================

function Get-Category {

    param (
        [string]$Extension
    )

    $Extension = $Extension.ToLower()

    foreach ($category in $rules.Keys) {

        if ($rules[$category] -contains $Extension) {
            return $category
        }
    }

    return "Other"
}


# ============================================================
# GET UNIQUE FILE PATH
# ============================================================

function Get-UniquePath {

    param (
        [string]$Folder,
        [string]$FileName
    )

    $target = Join-Path $Folder $FileName

    if (-not (Test-Path -LiteralPath $target)) {
        return $target
    }

    $base = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
    $ext  = [System.IO.Path]::GetExtension($FileName)

    $counter = 1

    do {

        $target = Join-Path `
            $Folder `
            "$base ($counter)$ext"

        $counter++

    } while (Test-Path -LiteralPath $target)

    return $target
}


# ============================================================
# CHECK WHETHER FILE IS STILL BEING DOWNLOADED
#
# We check the file size twice.
# If size changes, browser is still writing.
# ============================================================

function Test-FileFinished {

    param (
        [System.IO.FileInfo]$File
    )

    try {

        $size1 = $File.Length

        Start-Sleep -Milliseconds 300

        $File.Refresh()

        $size2 = $File.Length

        if ($size1 -ne $size2) {
            return $false
        }

        return $true
    }

    catch {

        return $false
    }
}


# ============================================================
# SORT A NEW DOWNLOAD
# ============================================================

function Sort-Download {

    param (
        [System.IO.FileInfo]$File
    )

    # Ignore temporary browser files
    if ($tempExtensions -contains $File.Extension.ToLower()) {
        return
    }


    # Ignore files that are still being written
    if (-not (Test-FileFinished $File)) {
        return
    }


    $category = Get-Category $File.Extension

    $destination = Join-Path `
        $downloads `
        $category


    # Create category folder
    if (-not (Test-Path -LiteralPath $destination)) {

        New-Item `
            -ItemType Directory `
            -Path $destination `
            -Force |
            Out-Null
    }


    $target = Get-UniquePath `
        -Folder $destination `
        -FileName $File.Name


    try {

        Move-Item `
            -LiteralPath $File.FullName `
            -Destination $target `
            -ErrorAction Stop

    }

    catch {
        # File was probably still being used.
        # It will be checked again on the next cycle.
    }
}


# ============================================================
# CHECK DOWNLOADS ROOT
# ============================================================

function Process-NewDownloads {

    $files = Get-ChildItem `
        -LiteralPath $downloads `
        -File `
        -ErrorAction SilentlyContinue


    foreach ($file in $files) {

        Sort-Download $file
    }
}


# ============================================================
# MOVE FILES AFTER 48 HOURS
# ============================================================

function Process-OldFiles {

    foreach ($category in $permanentFolders.Keys) {

        $stagingFolder = Join-Path `
            $downloads `
            $category

        $destination = $permanentFolders[$category]


        if (-not (Test-Path -LiteralPath $stagingFolder)) {
            continue
        }


        $files = Get-ChildItem `
            -LiteralPath $stagingFolder `
            -File `
            -ErrorAction SilentlyContinue


        foreach ($file in $files) {

            $age = (Get-Date) - $file.LastWriteTime


            if ($age.TotalHours -lt $delayHours) {
                continue
            }


            $target = Get-UniquePath `
                -Folder $destination `
                -FileName $file.Name


            try {

                Move-Item `
                    -LiteralPath $file.FullName `
                    -Destination $target `
                    -ErrorAction Stop

            }

            catch {
                # Try again during the next cycle.
            }
        }
    }
}


# ============================================================
# CONTINUOUS LOOP — no console output so it stays fully silent
# ============================================================

$oldFileCheck = Get-Date

while ($true) {

    # Check for new downloads every 2 seconds
    Process-NewDownloads

    # Check 48-hour files every 10 minutes
    if (((Get-Date) - $oldFileCheck).TotalMinutes -ge 10) {

        Process-OldFiles

        $oldFileCheck = Get-Date
    }

    Start-Sleep -Seconds 2
}
