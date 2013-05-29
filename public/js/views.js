
App.Views.App = Backbone.View.extend({

  initialize: function() {
    this.form = new App.Views.Form();
    this.preview = new App.Views.Preview();
    this.colors = new App.Views.Colors();
    this.results = new App.Views.Results();
    App.Vent.on('received:colors', this.search, this);
  },

  search: function(hexCodes) {
    $.ajax({
      url: 'http://localhost:8080/search',
      method: 'POST',
      data: {query: JSON.stringify(hexCodes)},
      dataType: 'json',
      success: function(results) {
        App.Vent.trigger('received:results', results);
      },
      error: function(err) {
        console.log('err', err);
      }
    });
  }

});

App.Views.Preview = Backbone.View.extend({

  el: '#preview',

  initialize: function() {
    App.Vent.on('selected:image', this.load, this);
  },

  load: function (image) {
    var fileReader = new FileReader();
    var self = this;
    fileReader.onloadend = function(e) {
      self.display(e.target.result, image);
    };
    fileReader.readAsDataURL(image);
  },

  display: function (source, filename) {
    App.coords = {};
    var img = $('<img>');
    img.attr('src', source);
    this.$el.html(img);
    this.$('img').Jcrop({
      onSelect: this.crop
    });
  },

  crop: function(coords) {
    App.coords = coords;
  }

});


App.Views.Form = Backbone.View.extend({

  el: '#upload',

  events: {
    'submit': 'submit',
    'change': 'change'
  },

  getFile: function() {
    return this.$('input[type=file]').get(0).files[0];
  },

  change: function() {
    var file = this.getFile();
    App.Vent.trigger('selected:image', file);
  },

  submit: function(e) {
    e.preventDefault();

    var file = this.getFile();

    if (file.type != 'image/png') {
      alert('Only supports PNG image files ...');
      return;
    }

    var formData = new FormData();
    formData.append('image[]', file);
    formData.append('coords[]', JSON.stringify(App.coords || {}));

    $.ajax({
      url: 'http://localhost:8080/upload',
      type: 'POST',
      data: formData,
      processData: false,
      contentType: false,
      success: function(json) {
        data = JSON.parse(json);
        App.Vent.trigger('received:colors', data);
      }
    });

  }

});


App.Views.Colors = Backbone.View.extend({

  el: '#colors',

  initialize: function() {
    console.log('listening for colors');
    App.Vent.on('received:colors', this.render, this);
  },

  render: function (hexCodes) {
    console.log('rendering colors');
    this.$el.empty();
    var len = hexCodes.length;
    for ( var i = 0; i < len; i++ ) {
      hex = hexCodes[i];
      var el = $('<li class="color">' + hex + '</li>');
      el.css('background', hex);
      this.$el.append(el);
    }
  }

});


App.Views.Results = Backbone.View.extend({

  el: '#results',

  initialize: function() {
    console.log('initialized results');
    App.Vent.on('received:results', this.render, this);
  },

  render: function (results) {
    console.log('rendering results');
    this.$el.empty();
    var len = results.length;
    for ( var i = 0; i < len; i++ ) {
      var filename = results[i][0]
      var el = $('<li>' + filename + '</li>');
      this.$el.append(el);
    }
  }
});