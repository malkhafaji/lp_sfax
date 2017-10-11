$(document).on('turbolinks:load', function() {
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
        'aTargets': [3, 4, 5, 6, 7, 8, 9, 10, 11]
      }
    ]
  });
});
$(document).ready(function() {
  $("#issu").dataTable();
});
