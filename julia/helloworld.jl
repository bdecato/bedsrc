###############################################################################
# helloworld.jl -- Messing around with Julia
#
# Mostly following the very helpful Gadfly tutorial found here:
# http://gadflyjl.org/stable/tutorial/#Tutorial
#
# @author Ben Decato
###############################################################################

using Gadfly, RDatasets

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

plot(iris, x=:SepalLength, y=:SepalWidth, Geom.point, Geom.line)

plot(iris, x=:SepalLength, y=:SepalWidth, color=:Species, Geom.point);
