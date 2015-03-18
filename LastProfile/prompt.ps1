. (Resolve-Path ~/Documents/WindowsPowershell/gitutils.ps1)
. (Resolve-Path ~/Documents/WindowsPowershell/hgutils.ps1)
. (Resolve-Path ~/Documents/WindowsPowershell/svnutils.ps1)

$Host.UI.RawUI.ForegroundColor = "White"

function prompt {
    # $path = ""
    $path = $pwd
    # $pathbits = ([string]$pwd).replace($env:userprofile, '~').split("\", [System.StringSplitOptions]::RemoveEmptyEntries)

    # if($pathbits.length -le 2) {
    #     $path = [string]::join('\', $pathbits)
    # }
    # else {
    #     $path = $pathbits[$pathbits.length - 2] + "\" + $pathbits[$pathbits.length - 1]
    # }

    # $path = $path.ToLower()

    # $user = $env:username.ToLower() + '@' + 'local'# [System.Environment]::MachineName.ToLower()
    # $user = '@'
    $user = ''

    # $userLocation = $user + ' ' + $path
    # $userLocation = '@ ' + $path

    # $host.UI.RawUi.WindowTitle = $user + ' ' + $pwd
    $host.UI.RawUi.WindowTitle = 'PS ' + $pwd

    # Write-Host($user + '') -nonewline -foregroundcolor Yellow
    Write-Host('PS ') -nonewline -foregroundcolor Gray
    Write-Host($path) -nonewline -foregroundcolor Gray

    if (isCurrentDirectoryGitRepository) {
        $status = gitStatus
        $currentBranch = gitBranchName
        # $currentBranch = $status["branch"]

        Write-Host(' [git ') -nonewline -foregroundcolor Yellow

        # Write-Host($currentBranch) -nonewline -foregroundcolor Cyan

        if ($status["ahead"] -eq $FALSE) {
            # We are not ahead of origin
            Write-Host($currentBranch) -nonewline -foregroundcolor Cyan
        } else {
            # We are ahead of origin
            Write-Host($currentBranch) -nonewline -foregroundcolor Red
        }

        # Write-Host(' A' + $status["added"]) -nonewline -foregroundcolor Green
        Write-Host(' ✚ ' + $status["added"]) -nonewline -foregroundcolor Green
        # Write-Host(' M' + $status["modified"]) -nonewline -foregroundcolor Yellow
        Write-Host(' ✎ ' + $status["modified"]) -nonewline -foregroundcolor Yellow
        # Write-Host(' D' + $status["deleted"]) -nonewline -foregroundcolor Magenta
        Write-Host(' ✘ ' + $status["deleted"]) -nonewline -foregroundcolor Magenta

        if ($status["untracked"] -ne $FALSE) {
            Write-Host(' ! ') -nonewline -foregroundcolor Red
        }


        Write-Host(']') -nonewline -foregroundcolor Yellow
    }
    elseif (isCurrentDirectoryMercurialRepository) {
        # $status = Get-HgStatus # mercurialStatus

        # $currentBranch = $status["branch"]
        $currentBranch = mercurialBranchName

        Write-Host(' [hg ') -nonewline -foregroundcolor Yellow
        Write-Host($currentBranch) -nonewline -foregroundcolor Magenta

        # Write-Host(' ✚ ' + $status["added"]) -nonewline -foregroundcolor Green
        # Write-Host(' ✎ ' + $status["modified"]) -nonewline -foregroundcolor Yellow
        # Write-Host(' ✘ ' + $status["deleted"]) -nonewline -foregroundcolor Cyan

        # if($status["missing"] -ne '0'){   
        #     Write-Host(' ! ' + $status["missing"]) -nonewline -foregroundcolor Magenta
        # }

        # if($status["untracked"] -ne '0'){
        #     Write-Host(' ? ' + $status["untracked"]) -nonewline -foregroundcolor Red
        # }
        Write-Host(']') -nonewline -foregroundcolor Yellow
    }
    elseif (isCurrentDirectorySvn) {
        # $status = svnStatus

        Write-Host(' [svn]') -nonewline -foregroundcolor Yellow
        <#
        Write-Host(' [svn ') -nonewline -foregroundcolor Yellow
        Write-Host(' A' + $status["added"]) -nonewline -foregroundcolor Green
        Write-Host(' M' + $status["modified"]) -nonewline -foregroundcolor Yellow
        Write-Host(' D' + $status["deleted"]) -nonewline -foregroundcolor Cyan
        Write-Host(' !' + $status["missing"]) -nonewline -foregroundcolor Magenta
        Write-Host(' ?' + $status["untracked"]) -nonewline -foregroundcolor Red

        Write-Host(']') -nonewline -foregroundcolor Yellow
        #>
    }
    else {
        # Write-Host($path) -nonewline -foregroundcolor Green
    }

    # '{0, 30}' -f '*'

    Write-Host
    Write-Host('$') -nonewline -foregroundcolor Gray
    # Write-Host('$') -nonewline -foregroundcolor Green
    # Write-Host('§') -nonewline -foregroundcolor Green

    # return ' '
    ' '
}