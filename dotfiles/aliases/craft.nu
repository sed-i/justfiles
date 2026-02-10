def pack [] {
    let crafts = ls | get name | parse "{tool}.yaml" | where {|row| $row.tool | str ends-with "craft" }
    let num = $crafts | length
    if $num != 1 {
    	print $"Expected a single *.craft.yaml file, found ($num)"
    	return
    }
    print "Packing"
    let command = $crafts | first | get tool
    ^$command pack
}
