
/* ------------------------------------------------------------------------- *
   View: App
 * ------------------------------------------------------------------------- */

App.Views.App = Backbone.View.extend({

  el: $('body'),

  events: {
    'click #search': 'search'
  },

  initialize: function() {
    this.form = new App.Views.Form();
    this.preview = new App.Views.Preview();
    this.colors = new App.Views.Colors();
    this.results = new App.Views.Results();
  },

  search: function(hexCodes) {
    $.ajax({
      url: 'http://localhost:1337/search',
      method: 'POST',
      data: {query: JSON.stringify(App.colors.enabled())},
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


/* ------------------------------------------------------------------------- *
   View: Preview
 * ------------------------------------------------------------------------- */

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


/* ------------------------------------------------------------------------- *
   View: Form
 * ------------------------------------------------------------------------- */

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
      url: 'http://localhost:1337/upload',
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

/* ------------------------------------------------------------------------- *
   View: Color
 * ------------------------------------------------------------------------- */

App.Views.Color = Backbone.View.extend({

  tagName: 'li',
  className: 'color',

  events: {
    'click': 'toggle'
  },

  initialize: function() {
    this.model.on('change:enabled', this.render, this);
  },

  toggle: function() {
    this.model.toggle();
  },

  render: function() {
    this.$el.css('background', this.model.get('color'));
    this.$el.toggleClass('disabled', !this.model.get('enabled'));
    return this;
  }

});

/* ------------------------------------------------------------------------- *
   View: Colors
 * ------------------------------------------------------------------------- */
App.Views.Colors = Backbone.View.extend({

  el: '#colors',

  initialize: function() {
    App.Vent.on('received:colors', this.load, this);
    App.colors.on('add', this.addOne, this);
  },

  load: function(hexCodes) {
    App.colors.reset();
    this.$el.empty();
    for ( var i = 0; i < hexCodes.length; i++ ) {
      App.colors.add({ color: hexCodes[i] });
    }
  },

  render: function (hexCodes) {
    this.$el.empty();
    App.colors.each(function(color) {
      this.addOne(color);
    }, this);
  },

  addOne: function(model) {
    var view = new App.Views.Color({ model: model });
    this.$el.append(view.render().el);
  }
});


/* ------------------------------------------------------------------------- *
   View: Results
 * ------------------------------------------------------------------------- */

App.Views.Results = Backbone.View.extend({

  el: '#results',

  template: _.template($('#results-template').html()),

  initialize: function() {
    console.log('initialized results');
    App.Vent.on('received:results', this.render, this);
  },

  render: function (results) {
    this.$el.html(this.template({ results: results }));
  }
});
