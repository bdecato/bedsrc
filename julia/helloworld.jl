###############################################################################
# helloworld.jl -- Messing around with Julia.
#
# Mostly following the very helpful Gadfly tutorial found here:
# http://gadflyjl.org/stable/tutorial/#Tutorial
#
# @author Ben Decato
###############################################################################

using Gadfly, RDatasets, DataFrames, Query

println("Hello world")
plot(y=[1,2,3])

iris = dataset("datasets", "iris")

# Omit the semicolon for quicker live rendering. display(p) to show.
p = plot(iris, x=:SepalLength, y=:SepalWidth, Geom.point);

img = SVG("iris_plot.svg", 14cm, 8cm)
draw(img, p)

function get_to_it(d)
  ppoint = plot(d, x=:SepalLength, y=:SepalWidth, Geom.point)
  pline = plot(d, x=:SepalLength, y=:SepalWidth, Geom.line)
  ppoint, pline
end

ps = get_to_it(iris)
map(display, ps)

plot(iris, x=:SepalLength, y=:SepalWidth, color=:Species, Geom.point);

### Query seems to be the main package for tidy-style data frame manipulation:

df = DataFrame(name=["John", "Sally", "Kirk"], age=[23., 42., 59.], children=[3,5,2])

# https://www.queryverse.org/Query.jl/stable/standalonequerycommands/

x = df |>
  @filter(_.age>50) |> # _.age>50 is anonymous function for i->i.age>50
  @map({_.name, _.children}) |>
  DataFrame

println(x)
