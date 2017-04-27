  var data = null;
  var graph = null;

  function assigner(options, data) {
    var x = options["Strike"] 
    var y = options["Days to Expiration"][0]
    var z = options["Price"] 
    data.add({
      x: x,
      y: y,
      z: z
    })
  }

  // Called when the Visualization API is loaded.
  function drawVisualization(stockOptions) {
    // Create and populate a data table.
    var data = new vis.DataSet();
    for (var i = 0; i < stockOptions.length; i++) {
      assigner(stockOptions[i], data)
    }

    // specify options
    var options = {
      width:  '600px',
      height: '600px',
      style: 'surface',
      showPerspective: true,
      showGrid: true,
      showShadow: false,
      keepAspectRatio: true,
      verticalRatio: 0.5,
      backgroundColor: 'light gray',
      xLabel: "Strike",
      yLabel: "Days to Expiration",
      zLabel: "Price",
      showGrid: true
    };
   
   
    // create a graph3d
    var container = document.getElementById('mygraph');
    graph3d = new vis.Graph3d(container, data, options);
    container.appendChild(graph3d);
    
  }
  
  