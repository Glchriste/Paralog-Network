
class TreeChart
  constructor: (data, file_name) ->
    @json = file_name
    @data = data
    @width = 1280
    @height = 500
    @fill_color = null
    @name_dict = {}
    @tags = []
    
    treeParse = (root) =>
      if root instanceof Array
        for item in root
          treeParse item
      else if root
        if root.name != "" and root.name
          @name_dict[root.name[0..3]] = 'named_node'
        if root.children
          treeParse root.children
    treeParse @data

    colorNode = (d) =>
        if d.name and d.name != ""
          d.color = @fill_color(d.name[0..3])
        else if d._children
          for child in d._children
            colorNode child

    update = (source) =>
      duration = (if d3.event and d3.event.altKey then 5000 else 500)
      
      # Compute the new tree layout.
      nodes = tree.nodes(root).reverse()
      
      # Normalize for fixed-depth.
      nodes.forEach (d) ->
        d.y = d.depth * 50
      
      # Update the nodes…
      node = vis.selectAll("g.node").data(nodes, (d) ->
        d.id or (d.id = ++i)
      )
      
      # Enter any new nodes at the parent's previous position.
      nodeEnter = node.enter().append("svg:g").attr("class", "node").attr("transform", (d) ->
        "translate(" + source.y0 + "," + source.x0 + ")"
      ).on("click", (d) ->
        toggle d
        update d
      )

      nodeEnter.append("svg:circle").attr("r", 1e-6).style "fill", (d) =>
        colorNode d
        #(if d._children then "lightsteelblue" else "#fff")

      nodeEnter.append("svg:text").attr("x", (d) ->
        (if d.children or d._children then -10 else 10)
      ).attr("dy", ".35em").attr("text-anchor", (d) ->
        (if d.children or d._children then "end" else "start")
      ).text((d) ->
        d.name
      ).style "fill-opacity", 1e-6
      
      # Transition nodes to their new position.
      nodeUpdate = node.transition().duration(duration).attr("transform", (d) ->
        "translate(" + d.y + "," + d.x + ")"
      )
      nodeUpdate.select("circle").attr("r", 4.5).style "fill", (d) ->
        colorNode d
        #(if d._children then "lightsteelblue" else "#fff")

      nodeUpdate.select("text").style "fill-opacity", 1
      
      # Transition exiting nodes to the parent's new position.
      nodeExit = node.exit().transition().duration(duration).attr("transform", (d) ->
        "translate(" + source.y + "," + source.x + ")"
      ).remove()
      nodeExit.select("circle").attr "r", 1e-6
      nodeExit.select("text").style "fill-opacity", 1e-6
      
      # Update the links…
      link = vis.selectAll("path.link").data(tree.links(nodes), (d) ->
        d.target.id
      )
      
      # Enter any new links at the parent's previous position.
      link.enter().insert("svg:path", "g").attr("class", "link").attr("d", (d) ->
        o =
          x: source.x0
          y: source.y0

        diagonal
          source: o
          target: o

      ).transition().duration(duration).attr "d", diagonal
      
      # Transition links to their new position.
      link.transition().duration(duration).attr "d", diagonal
      
      # Transition exiting nodes to the parent's new position.
      link.exit().transition().duration(duration).attr("d", (d) ->
        o =
          x: source.x
          y: source.y

        diagonal
          source: o
          target: o

      ).remove()
      
      # Stash the old positions for transition.
      nodes.forEach (d) ->
        d.x0 = d.x
        d.y0 = d.y

    # Toggle children.
    toggle = (d) =>
      if d.children
        d._children = d.children
        d.children = null
      else
        d.children = d._children
        d._children = null

    m = [20, 120, 20, 120]
    w = @width - m[1] - m[3]
    h = @height - m[0] - m[2]
    i = 0
    root = undefined
    tree = d3.layout.tree().size([h, w])
    diagonal = d3.svg.diagonal().projection((d) ->
      [d.y, d.x]
    )
    vis = d3.select("#vis").append("svg:svg").attr("width", w + m[1] + m[3]).attr("height", h + m[0] + m[2]).append("svg:g").attr("transform", "translate(" + m[3] + "," + m[0] + ")")
    
    d3.json @json, (json) =>

      toggleAll = (d) =>
        treeParse d
        if d.children
          d.children.forEach toggleAll
          toggle 

      for key, value of @name_dict
        @tags.push key

      @fill_color = d3.scale.ordinal()
      .domain(@tags)
      .range(colorbrewer.Set3[9])

      @fill_color_cbs = d3.scale.ordinal() #cbs = Color-blind safe
      .domain(@tags)
      .range(colorbrewer.BuGn[9])

      root = @data
      root.x0 = h / 2
      root.y0 = 0
      root.children.forEach toggleAll
      update root

root = exports ? this

#Export our stuff and get the javascript compiling...
root = exports ? this
$ ->
  #Make our charts from data (json file)
  tree_chart = null
  render_tree = (json) ->
    file_name = "data/best_tree.json"
    tree_chart = new TreeChart json, file_name

  #Handle the views...

  # Render our visualization charts
  d3.json "data/best_tree.json", render_tree

