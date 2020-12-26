# A cool few lines I saw on twitter, tweeted by @AedinCulhane. I plan on expanding this relatively soon.
require(magick)
require(tesseract)
img <- image_read("~/Downloads/hb_screenshot.png")
image_ocr(img)
