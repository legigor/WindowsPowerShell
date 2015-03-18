# Mercurial (hg) functions
# Kornelije Sajler (http://learnaholic.me)
# Adopted from Git version of:
# Mark Embling (http://www.markembling.info/)
 
# You can clone it by
# hg clone https://xajler@bitbucket.org/xajler/powershell-prompt-for-mercurial/
# And find source here:
# http://bitbucket.org/xajler/powershell-prompt-for-mercurial/src/
 
# Is the current directory a Mercurial repository/working copy?
function isCurrentDirectoryMercurialRepository {
    if ((Test-Path ".hg") -eq $TRUE) {
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
 
# Get the current branch
function mercurialBranchName {
    $currentBranch = ''
    hg branch | foreach {
        $currentBranch += $_
    }
   # Write-Host($currentBranch)
    return $currentBranch
}
 
# Extracts status details about the repo
function mercurialStatus {
    $untracked = 0
    $added = 0
    $modified = 0
    $deleted = 0
    $missing = 0
 
    $output = hg status
 
    #$branchbits = $output[0].Split(' ')
    #$branch = $branchbits[$branchbits.length - 1]
    #$branch = $branchbits[$branchbits.length - 1]
 
   # Write-Host($output)
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

#-------------------------------------------------------------------------------------------------------------

function Hg-Commit([string] $m = $(Read-Host -prompt "-m")){ 
    hg commit -m $m 
}

function Hg-Amend(){ 
    hg commit --amend 
}

Set-Alias hgc Hg-Commit
Set-Alias hga Hg-Amend