var ItemTypeListHelper = function (data, config) {
  'use strict';
  var  _viewModel,
       _applyKoBindings,
       _currentContext,
       _mapToJSON,
       _setup;


  _applyKoBindings = function () {

    _viewModel = ko.mapping.fromJS(data);

    _viewModel.item_types.removeAll();
    var model = ko.mapping.fromJS(data);
    var mappedItemTypes = ko.utils.arrayMap(data.item_types, function(item_type) {
      return new ItemType(item_type.sap_number, item_type.material_type, item_type.description,
                          item_type.image, item_type.rating, item_type.inventory_quantity);
    });
    _viewModel.item_types( mappedItemTypes );

    $( data.item_types ).each(function( key, item_type ) {
      $('#dataTables-example > tbody:last-child')
        .append('<tr>' +
                  '<td>' + item_type.sap_number + '</td>' +
                  '<td>' + item_type.material_type + '</td>' +
                  '<td>' + item_type.description + '</td>' +
                  '<td class="item_type" data-sap_number="' + item_type.sap_number + '">' + item_type.inventory_quantity + '</td>' +
                  '<td><a href="#"><i data-image="' + item_type.image + '" class="fa fa-file-image-o"></i></a></td>' +
                '</tr>');
    });

    $('#dataTables-example').dataTable({"autoWidth": false, "info":true, "lengthMenu": [10, 20,50],
      "order": [[ 0, "desc" ]]
    });

    _viewModel.openImage = function() {
      $('.imagepreview').attr( 'src', this.image() );
      $('#imagemodal').modal('show');
    };

    _viewModel.displayStats = function() {
      location.href="/chart?sap_number=" + this.sap_number();
    };

    ko.applyBindings(_viewModel, _currentContext[0]);
  };

  $(document).on('click', '.fa-file-image-o', function() {
    $('.imagepreview').attr( 'src', $(this).attr('data-image') );
    $('#imagemodal').modal('show');
  });

  $(document).on('click', '.item_type', function() {
    $('#locationTable').find('tr:gt(0)').remove();
    $.ajax({
      type: "GET",
      data: "sap_number=" + $(this).attr('data-sap_number'),
      url: "/items-per-location",
    }).done(function(result) {
      ko.utils.arrayMap(JSON.parse(result), function(item_per_location) {
      $('#locationTable > tbody:last-child')
        .append('<tr>' +
                  '<td class="stock_take_capitalize">' + item_per_location.location + '</td>' +
                  '<td>' + item_per_location.quantity + '</td>' +
                '</tr>');
     /*   $("#statsTable tbody").append("<tr class=" + warning_class + "><td>" + k + "</td><td>" + item_type.description + "</td>" +
                                      "<td>" +  v.physical_count + "</td>" +
                                      "<td>" + v.inventory_quantity + "</td>" +
                                      "<td>" + Math.abs(v.physical_count - v.inventory_quantity) + "</td>" +
                                      "<td>" + v.expired + "</td>" +
                                      "</tr>");
   */   });
      $('#locationmodal').modal('show');
    });

  });

  _mapToJSON = function (model) {
      var ignoreMapping;
      ignoreMapping = {
         ignore: []
      };
      return ko.mapping.toJSON(model, ignoreMapping);
  };

  var ItemType = function(sap_number, material_type, description, image, rating, color, inventory_quantity) {
      this.sap_number = ko.observable(sap_number);
      this.material_type = ko.observable(material_type);
      this.description = ko.observable(description);
      this.image = ko.observable(image);
      this.rating = ko.observable(rating);
      this.color = ko.observable(color);
      this.inventory_quantity = ko.observable(inventory_quantity);
  }

  _setup = function() {
      _currentContext = $('#content_left');
      _applyKoBindings();
  };

  return {
      setup: _setup
  };

};
