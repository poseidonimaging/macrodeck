module AccountHelper
	# node should be a DataGroup...
	def get_javascript_for_node(node, rootNode = "root")
		tmpJS = "meta = { label: '" + h(node.title) + " (" + UUIDService.lookupUUID(node.type) + ")', id: '#{node.groupingid}' };\n" 
		tmpJS = tmpJS + "var node" + node.groupingid.gsub("-", "") + " = new YAHOO.widget.TextNode(meta, #{rootNode}, false);\n"

		if node.items?
			node.items.each do |item|
				tmpJS = tmpJS + "meta = { label: '" + h(item.title) + " (" + UUIDService.lookupUUID(item.type) + ")', id: '#{item.dataid}' };\n"
				tmpJS = tmpJS + "var node" + item.dataid.gsub("-", "") + " = new YAHOO.widget.TextNode(meta, node" + node.groupingid.gsub("-", "") + ");\n"

				if item.children?
					item.children.each do |child|
						# RECURSION FOR THE WIN!
						# (this function will keep calling itself for subgroups of an item)
						tmpJS = tmpJS + get_javascript_for_node(child, "node" + item.dataid.gsub("-", ""))
					end
				end
			end
		end

		return tmpJS
	end
end
