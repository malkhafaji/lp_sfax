$(document).ready ->
  $('#fax_records').dataTable
    processing: true
    serverSide: true
    ajax: $('#fax_records').data('source')
    pagingType: 'full_numbers',
    bProcessing: true,
    #"bSort": true
    # columns: [
    #   { data: 'id' }
    # ]
  return

