class TreeChart
  constructor: (data) ->
    @data = data
    @vis = null
    @width = 1280
    @height = 800
    @m = [20, 120, 20, 120]
    @w = @width - @m[1] - @m[3]
    @h = @height - @m[0] - @m[2]
    @root = null

    @tree = d3.layout.tree().size([h, w])
    @diagonal = d3.svg.diagonal().projection((d) -> [d.y, d.x])

    create_vis: () =>
      @vis = d3.select("#vis").append("svg")
        .attr("width", @width)
        .attr("height", @height)
        .attr("id", "svg_vis")

root = exports ? this
$ ->
  #Make our charts from data (json file)
  chart = null
  tree_chart = null
  render_tree = (json) ->
    tree_chart = new TreeChart json

  d3.json "data/best_tree.json", render_tree