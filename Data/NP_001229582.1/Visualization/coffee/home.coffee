class TreeChart
  constructor: (data) ->
    @data = data
    @vis = null
    @m = [20, 120, 20, 120]
    @w = 1280 - @m[1] - @m[3]
    @h = 800 - @m[0] - @m[2]
    @i = 0
    @root = null
    @tree = d3.layout.tree().size([@h, @w])
    @diagonal = d3.svg.diagonal().projection((d) -> [d.y, d.x])
    #console.log @data
    #for name, children of @data
    #  console.log children

    @root = @data
    @root.x0 = @h / 2
    @root.y0 = 0
    console.log data
    treeParse = (root) ->
      #console.log root
      if root instanceof Array
        for item in root
          treeParse item
      if root.name
        console.log root
      if root.children
        treeParse root.children
    treeParse @data

    toggle = (d) ->
      if d.children
        d._children = d.children
        d.children = null
      else
        d.children = d._children
        d._children = null

   
    toggleAll = (d) ->
      if d.children
        d.children.forEach(toggleAll)
        toggle(d)

    update = (source) =>
      @duration = d3.event && d3.event.altKey ? 5000 : 500
      #Compute the new tree layout
      @nodes = @tree.nodes(root).reverse()
      #Normalize for fixed depth
      @nodes.forEach (d) ->
        d.y = d.depth * 50
      @node = @vis.selectAll("g.node").data(@nodes, (d) -> d.id or (d.id = ++@i))

      #Enter any new nodes at the parent's previous position.
      @nodeEnter = @node.enter().append("svg:g").attr("class", "node").attr("transform", (d) ->
        "translate(" + source.y0 + "," + source.x0 + ")").on("click", (d) => 
        toggle(d)
        update(d)
        return)


      @nodeEnter.append("svg:circle")
      .attr("r", 1e-6)
      .style("fill", (d) -> d._children ? "lightsteelblue" : "#fff")

      @nodeEnter.append("svg:text")
      .attr("x", (d) ->  d.children || d._children ? -10 : 10)
      .attr("dy", ".35em")
      .attr("text-anchor", (d) -> d.children || d._children ? "end" : "start")
      .text((d) -> d.name)
      .style("fill-opacity", 1e-6)

      #Transition nodes to their new position
      @nodeUpdate = @node.transition()
      .duration(@duration)
      .attr("transform", (d) -> "translate(" + d.y + "," + d.x + ")")

      @nodeUpdate.select("circle")
      .attr("r", 4.5)
      .style("fill", (d) -> d._children ? "lightsteelblue" : "#fff")

      @nodeUpdate.select("text")
      .style("fill-opacity", 1)

      #Transition existing nodes to parents new position
      @nodeExit = @node.exit().transition()
      .duration(@duration)
      .attr("transform", (d) -> "translate(" + source.y + "," + source.x + ")")
      .remove()

      @nodeExit.select("circle")
          .attr("r", 1e-6)

      @nodeExit.select("text")
          .style("fill-opacity", 1e-6)

      #Update the links
      @link = @vis.selectAll("path.link").data(@tree.links(@nodes), (d) -> d.target.id)

      #Enter new links at the parent's previous position
      @link.enter().insert("svg:path", "g")
      .attr("class", "link")
      .attr("d", (d) =>
        o = {x: source.x0, y: source.y0}
        @diagonal({source: o, target: o})
      ).transition()
      .duration(@duration)
      .attr("d", @diagonal)

      #Transition links to their new position
      @link.transition()
      .duration(@duration)
      .attr("d", @diagonal)

      #Transition exiting nodes to their parents new position
      @link.exit().transition()
      .duration(@duration)
      .attr("d", (d) =>
        o = {x: source.x, y: source.y}
        @diagonal({source: o, target: o})
      )
      .remove()

      #Stash the old positions for transition
      @nodes.forEach (d) ->
        d.x0 = d.x
        d.y0 = d.y
      

      

    this.create_vis()
    @root.children.forEach(toggleAll)
    update @root

    #this.create_nodes()
    

    # Create node objects from original data that will serve as the data behind each bubble in the chart.
    # Add each node to @nodes for use in the chart.
  create_nodes: () =>
    @data.forEach (d) =>
      node = {
        name: d.name
        children: d.children
        # x: Math.random() * 1000
        # y: Math.random() * 800
        # color: @fill_color(d.name)
      }
      @nodes.push node

    @tree = d3.layout.tree().size([@h, @w])
    @diagonal = d3.svg.diagonal().projection((d) -> [d.y, d.x])

  create_vis: () =>
    @vis = d3.select("#vis").append("svg:svg")
      .attr("width", @w + @m[1] + @m[3])
      .attr("height", @h + @m[0] + @m[2])
      .attr("id", "svg_vis")
      .append("svg:g")
      .attr("transform", "translate(" + @m[3] + "," + @m[0] + ")")
  
    

  


root = exports ? this
$ ->
  #Make our charts from data (json file)
  chart = null
  tree_chart = null
  render_tree = (json) ->
    tree_chart = new TreeChart json

  d3.json "data/best_tree.json", render_tree