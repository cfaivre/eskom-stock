var ItemListHelper = function (data, config) {
  'use strict';
  var  _viewModel,
       _applyKoBindings,
       _currentContext,
       _mapToJSON,
       _setup;

  _applyKoBindings = function () {

    _viewModel = ko.mapping.fromJS(data);
    _viewModel.items.removeAll();
    var model = ko.mapping.fromJS(data);
    var mappedItems = ko.utils.arrayMap(data.items, function(item) {
      return new Item(item.rfid, item.location, item.manufacture_date,
                      item.expire_date, item.purchase_order_number,
                      item.sap_number, item.project_name, item.supplier,
                      item.storage_location);
    });

    _viewModel.items( mappedItems );

    $( data.items ).each(function( key, item ) {
      $('#dataTables-example > tbody:last-child')
        .append('<tr>' +
                  '<td>' + item.rfid + '</td>' +
                  '<td>' + item.location + '</td>' +
                  '<td>' + item.storage_location + '</td>' +
                  '<td>' + item.project_name + '</td>' +
                  '<td>' + item.purchase_order_number +
                  '<td>' + item.supplier + '</td>' +
                  '<td>' + item.manufacture_date +
                  '<td>' + item.expire_date +
                  '<td>' + item.sap_number +
                '</tr>');
    });
    $('#dataTables-example').dataTable({"autoWidth": false, "info":true, "lengthMenu": [10, 20,50],
      "order": [[ 0, "desc" ]]
    });
/*    $('#dataTables-example').dataTable({"scrollY": 500,
                "iDisplayLength": 10,
                "scrollX": true,
                "paging":   true,
                "responsive": true,
                "searching": true});*/

    ko.applyBindings(_viewModel, _currentContext[0]);
  };

  _mapToJSON = function (model) {
      var ignoreMapping;
      ignoreMapping = {
         ignore: []
      };
      return ko.mapping.toJSON(model, ignoreMapping);
  };

  var Item = function(rfid, location, manufacture_date, expire_date, purchase_order_number, sap_number, project_name, supplier, storage_location) {
      this.rfid = ko.observable(rfid);
      this.location = ko.observable(location);
      this.manufacture_date = ko.observable(manufacture_date);
      this.expire_date = ko.observable(expire_date);
      this.purchase_order_number = ko.observable(purchase_order_number);
      this.sap_number = ko.observable(sap_number);
      this.project_name = ko.observable(project_name);
      this.supplier = ko.observable(supplier);
      this.storage_location = ko.observable(storage_location);
  }

  _setup = function() {
    _currentContext = $('#content_left');
    _applyKoBindings();
  };

  return {
      setup: _setup
  };

};
