$(document).on('turbolinks:load', function() {
  $("#issu").dataTable();
  $('#fax_records').dataTable({
    processing: true,
    serverSide: true,
    ajax: $('#fax_records').data('source'),
    pagingType: 'full_numbers',
    bProcessing: true,
    order: [[0, "desc"]],
    aoColumnDefs: [
      {
        'bSortable': false,
        'aTargets': [3, 4, 5, 6, 7]
      }
    ]
  });
});
