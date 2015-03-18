function isCurrentDirectorySvn {
    if ((Test-Path ".svn") -eq $TRUE) {
        return $TRUE
    }
 
    # Test within parent dirs
    $checkIn = (Get-Item .).parent
    while ($checkIn -ne $NULL) {
        $pathToTest = $checkIn.fullname + '/.hg'
        if ((Test-Path $pathToTest) -eq $TRUE) {
            return $TRUE
        } else {
            $checkIn = $checkIn.parent
        }
    }
 
    return $FALSE
}

function svnStatus {
    $untracked = 0
    $added = 0
    $modified = 0
    $deleted = 0
    $missing = 0
 
    $output = svn status
 
    $output | foreach {
        if ($_ -match "^R") {
            $deleted += 1
        }
        elseif ($_ -match "^M") {
            $modified += 1
        }
        elseif ($_ -match "^A") {
            $added += 1
        }
        elseif ($_ -match "^\!") {
            $missing += 1
        }
        elseif ($_ -match "^\?") {
            $untracked += 1
        }
    }
 
    return @{"untracked" = $untracked;
             "added" = $added;
             "modified" = $modified;
             "deleted" = $deleted;
             "missing" = $missing}
}