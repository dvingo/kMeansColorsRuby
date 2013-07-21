require 'RMagick'
include Magick

filename = ARGV[0]
if not filename
  puts "Provide image filename"
  exit 1
end

unless File.file?(filename)
  puts "'#{filename}' could not be found."
  exit 2
end

def get_pixels(img)
  img.get_pixels(0, 0, img.columns, img.rows)
end

def euclidean(p1, p2)
  d = [(p1.red - p2.red) ** 2, (p1.green - p2.green) ** 2, (p1.blue - p2.blue) ** 2]
  Math.sqrt(d.reduce(:+))
end

def calculate_center(pixels)
  new_red = (pixels.reduce(0) { |sum, p| sum += p.red }) / pixels.length
  new_green = (pixels.reduce(0) { |sum, p| sum += p.green }) / pixels.length
  new_blue = (pixels.reduce(0) { |sum, p| sum += p.blue }) / pixels.length
  new_intensity = (pixels.reduce(0) { |sum, p| sum += p.intensity }) / pixels.length
  Pixel.new(new_red, new_green, new_blue, new_intensity)
end

def kmeans(pixels, k, min_diff)
  clusters = pixels.sample(k)
  puts "clusters: #{clusters}"

  outer_loop = 0
  while true
    bestmatches = Array.new(k) {[]}
    puts "Iteration #{outer_loop}"

     #Find which centroid is the closest for each pixel
    pixels.each do |p|
      bestmatch = 0
      clusters.each_with_index do |cluster, i|
        d = euclidean(cluster, p)
        if d < euclidean(clusters[bestmatch], p)
          bestmatch = i
        end
      end
      bestmatches[bestmatch] << p
    end

    # Move the centroids to the average of their members
    diff = 0
    clusters.each_with_index do |cluster, i|
      new_cluster = calculate_center(bestmatches[i])
      clusters[i] = new_cluster
      diff = euclidean(cluster, new_cluster)
    end

    break if diff < min_diff

    outer_loop += 1
  end
  clusters
end

img = Image.read(filename).first
resized_img = img.thumbnail(img.columns * 0.01, img.rows * 0.01)

img_pixels = get_pixels(resized_img)
#puts "pixels: #{img_pixels}"

puts "kmeans: #{kmeans(img_pixels, 3, 100)}"
output_pixels = kmeans(img_pixels, 3, 100)
i = 0
output_pixels.each do |pixel|
  puts "rgbi: #{pixel.red / 257}, #{pixel.green / 257}, #{pixel.blue / 257}, #{pixel.intensity / 257}"
  puts "rgb: #{(pixel.red / 257).to_s(16)}#{(pixel.green / 257).to_s(16)}#{(pixel.blue / 257).to_s(16)}"
  img = Image.new(200, 200)
  pixel_data = []
  (1..40000).each { |x| pixel_data << pixel }
  puts "pixel data length #{pixel_data.length}"
  #img.import_pixels(0, 0, 200, 200, "RGB", pixel_data, QuantumPixel)
  img.store_pixels(0, 0, 200, 200, pixel_data)
  #img.import_pixels(0, 0, 200, 200, "RGB", pixel_data)
  img.write("#{i}.png")
  i += 1
end

