module GraphDataSystem
  include OpenFlashChart
  # Will return a OpenFlashChart object that show a 
  # line graph for each element in graphs argument
  #
  # * graphs: An array of hashes. Each hash will
  #   have the following keys
  #   - text: The title for that group of values
  #   - values: The array of values
  #
  # * options: Possible options are:
  #   - title: The title of the graph
  #   - y_leyend: A string to show below
  #   - x_leyend: A string to show on the left
  #   - range: Y-Axis range defined as an array 
  #     like this [ min value, max value, step]
  #   - x_labels: Array of strings for the labels 
  #     below
  def graph_data_for graphs, options = {}

    # Colors
    dark_grey = '#7C7764'
    light_grey = '#DDDDDD'
    dark_blue = '#567FB9'

    # Create graph object and set title
    graph = OpenFlashChart.new
    graph.bg_colour = '#FFFFFF'
    graph.set_title(options[:title].to_s)

    # Leyends
    leyend_style = "{font-size: 15px; color: #{dark_grey}}"

    y_legend = YLegend.new(options[:y_leyend].to_s)
    y_legend.set_style(leyend_style)
    graph.set_y_legend(y_legend)

    x_legend = XLegend.new(options[:x_leyend].to_s)
    x_legend.set_style(leyend_style)
    graph.set_x_legend(x_legend)

    # Y-Axis range and colors
    if options[:range]
      range = options[:range]
    else
      max = graphs.map{|g| g[:values].compact.max || 1}.max * 1.1
      step = case max
             when 0..1      then  0.2
             when 1..10     then  1
             when 10..100   then 10
             when 100..1000 then 100
             end

      range = [0, max, step]
    end

    y = YAxis.new
    y.set_range(*range)
    y.colour = light_grey
    y.grid_colour = light_grey

    graph.y_axis = y

    # X-Axis colors
    x = XAxis.new
    x.colour = light_grey
    x.grid_colour = light_grey

    # X-Axis labels
    if options[:x_labels]
      x_labels = XAxisLabels.new
      x_labels.labels = options[:x_labels].map{|s| XAxisLabel.new( s, '#000000', 12, 'diagonal')}
      x.set_labels(x_labels)
    end

    graph.x_axis = x


    # Data
    line_colors = [dark_blue, light_grey].slice 0..(graphs.length - 1)

    graphs.reverse.each_with_index do |g, n|
      line = LineDot.new
      line.text = g[:text].to_s
      line.colour = line_colors.reverse[n]
      line.width = 4
      line.dot_size = 5
      line.values = g[:values]

      graph.add_element(line)
    end

    graph
  end
end
