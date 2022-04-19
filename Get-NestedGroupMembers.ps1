function Get-NestedMembers {
    param ($ADObjDN,$parentGroup = "",$depth = 0,$NestedMembers = @()) #DN

    <#
    $ADObjDN = $groupDN
    $parentGroup = ""
    $depth = 0
    $NestedMembers = @()
    #>

    $Obj = Get-ADObject $ADObjDN -Properties sAMAccountName,DistinguishedName,CanonicalName,ObjectClass,member,Name

    switch -Regex ($obj.ObjectClass) {
        "User|Computer" {
            if ($NestedMembers -contains $obj.DistinguishedName) {continue}
            New-Object PSObject -Property @{
                sAMAccountName = $obj.sAMAccountName
                Name = $obj.Name
                DistinguishedName = $obj.DistinguishedName
                CanonicalName = $obj.CanonicalName
                ParentGroup = $parentGroup
                ObjectClass = $obj.ObjectClass
                depth = $depth
                } | Write-Output
            }
        "Group" {
            if ($NestedMembers -contains $obj.DistinguishedName) {continue}
            $NestedMembers += $obj.DistinguishedName
            foreach ($member in $obj.member) {
                $returned = Get-NestedMembers $member ($obj.DistinguishedName) ($depth + 1) $NestedMembers
                $returned | Write-Output
                $NestedMembers += $returned | select -ExpandProperty DistinguishedName
                }
            }
        }
    }

$groupDN = get-adgroup "GLS_ACC_8021x Test Computers" | select -ExpandProperty DistinguishedName
Get-NestedMembers $groupDN | select -ExpandProperty samaccountname

$groupDN = get-adgroup "SG-Removable Media Write Access Block Exempt" | select -ExpandProperty DistinguishedName
#Get-NestedMembers $groupDN
