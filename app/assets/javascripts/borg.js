$(window).load(function() {
  var navheight = $('#navigation>.navbar').outerHeight(true);
  return $('#maincontent>.container-fluid').height($('body').height() - navheight);
});

$(window).resize(function() {
  var navheight = $('#navigation>.navbar').outerHeight(true);
  return $('#maincontent>.container-fluid').height($('body').height() - navheight);
});


// autocomplete/typeahead feature for some search-fields
$(document).ready(function() {
  return $('#titlesearch').typeahead({
    source: function(typeahead, query) {
      var _this = this;
      if (query.length >= 2) return $.ajax({
        url: "/ajax/autocomplete/titlesearch/" + query,
				beforeSend: function(xhr) {
					xhr.setRequestHeader('Accept', 'text/javascript');
				},
        success: function(data) {
          return typeahead.process(data);
        }
      });
    },
    property: "name"
  });
});


$(document).ready(function() {
  return $('#plotsearch').typeahead({
    source: function(typeahead, query) {
      var _this = this;
      if (query.length >= 3) return $.ajax({
        url: "/ajax/autocomplete/plotsearch/" + query,
				beforeSend: function(xhr) {
					xhr.setRequestHeader('Accept', 'text/javascript');
				},
        success: function(data) {
          return typeahead.process(data);
        }
      });
    },
    property: "text",
    selectproperty: "name",
    onselect: function(obj) {
      var val;
      val = JSON.parse(this.$menu.find('.active').attr('data-value'));
      return this.$element.val(val[this.options.selectproperty]);
    }
  });
});


$(document).ready(function() {
$('.to_modal').click(function(e) {
    e.preventDefault();
    var href = $(e.target).attr('href');
    if (href.indexOf('#') == 0) {
        $(href).modal('open');
    } else {
        $.get(href, function(data) {
            $('<div class="modal fade" >' + data + '</div>').modal();
        });
    }
});
});

// lazyload all images
$(document).ready(function() {
		$("img.lazy").lazyload({ threshold : 100, effect : "fadeIn" });
});



$(document).ready(function() {
	$('input.imdb_verify').click(function() {
		var that = $(this);
		if (that.attr('checked')) {
		$.ajax({
		        url: "/movies/" + that.attr('movie') + "/imdbvalid",
		        dataType: 'html',
						beforeSend: function(xhr) {
							xhr.setRequestHeader('Accept', 'text/javascript');
						},
		        success: function(data){
							that.fadeOut(150).delay(150).fadeIn(150);
		          //that.attr('checked', 'checked');
		        }
		       });
		} else {
			$.ajax({
			        url: "/movies/" + that.attr('movie') + "/imdbinvalid",
			        dataType: 'html',
							beforeSend: function(xhr) {
								xhr.setRequestHeader('Accept', 'text/javascript');
							},
								// 			        success: function(data){
								// that.fadeOut(150).delay(150).fadeIn(150);
								// 			          //that.attr('checked', 'checked');
								// 			        }
			       });
		}
		
	});
});