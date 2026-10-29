Grover.configure do |config|
  config.options = {
    format: "A4",
    landscape: true,
    margin: {
      top: "15mm",
      bottom: "15mm",
      left: "15mm",
      right: "15mm"
    },
    print_background: true
  }
end
