var StockTakeListHelper = function (data, config) {
  'use strict';
  var  _viewModel,
       _applyKoBindings,
       _currentContext,
       _mapToJSON,
       _itemTypeCallback,
       _setup;


  _applyKoBindings = function () {

    $("#alert").hide();

    $(".alert-close").click(function() {
      $(this).parent().hide();
    });

    _viewModel = ko.mapping.fromJS(data);

    _viewModel.stock_takes.removeAll();
    var model = ko.mapping.fromJS(data);
    var mappedStockTakes = ko.utils.arrayMap(data.stock_takes, function(stock_take) {
      return new StockTake(stock_take.created_at, stock_take._id, stock_take.stats);
    });
    _viewModel.stock_takes( mappedStockTakes );

    _viewModel.displayStats = function( stats ) {
      $("#statsTable tbody").empty();

      $.each(stats, function(k,v){
        $.ajax({
          type: "GET",
          data: "sap_number=" + k,
          url: "/item_type",
        }).done(function(result) {
          ko.utils.arrayMap(JSON.parse(result), function(item_type) {
            $("#statsTable tbody").append("<tr><td>" + k + "</td><td>" + item_type.description + "</td><td>" +  v + "</td></tr>");
          });
          $('#statsmodal').modal('show');
        });
      });
    }

    _viewModel.displayStatsChart = function( stats ) {
      $.each(stats, function(k,v){
        $.ajax({
          type: "GET",
          data: "sap_number=" + k,
          url: "/item_type",
        }).done(function(result) {
          ko.utils.arrayMap(JSON.parse(result), function(item_type) {
            //$("#statsTable tbody").append("<tr><td>" + k + "</td><td>" + item_type.description + "</td><td>" +  v + "</td></tr>");
          });
console.log('hello');
          $('#statsChartModal').modal('show');
        });
      });
    }

    _viewModel.emailStats = function( id, date ) {
      $("#alert").hide();
      $("#alert").removeClass('alert-danger');
      $("#alert").removeClass('alert-success');
      $.ajax({
        type: "POST",
        data: "id=" + id + "&date=" + date,
        url: "/stock_take/mail",
      }).done(function(result) {
        $("#alert").show();
        $("#alert").addClass('alert-success');
        $("#alert-text").text('Success sending mail!');
      }).fail(function(result) {
        $("#alert").show();
        $("#alert").addClass('alert-danger');
        $("#alert").addClass('alert-dismissable');
        $("#alert-text").text('Error sending mail!');
      });
    }

    ko.applyBindings(_viewModel, _currentContext[0]);

  };

  $('#statsChartModal').on('shown.bs.modal', function (event) {
console.log('blabla');
    var chart_data =
            [ { value: 2,
                label: 2,
                color: "#00CC00",
                highlight: "#99EB99" } ]
      var ctx = document.getElementById("myChart").getContext("2d");
      var myPieChart = new Chart(ctx).Pie(chart_data);
  });

  _mapToJSON = function (model) {
    var ignoreMapping;
    ignoreMapping = {
       ignore: []
    };
    return ko.mapping.toJSON(model, ignoreMapping);
  };

  var StockTake = function(created_at, _id, stats) {
    this.created_at = ko.observable(created_at);
    this._id = ko.observable(_id);
    this.stats = ko.observable(stats);
  }

  _setup = function() {
    _currentContext = $('#content_left');
    _applyKoBindings();
  };

  return {
    setup: _setup
  };

};
