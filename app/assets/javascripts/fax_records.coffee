$(document).ready ->
  $('#fax_records').dataTable
    processing: true
    serverSide: true
    ajax: $('#fax_records').data('source')
    pagingType: 'full_numbers',
    bProcessing: true,
    # columns: [
    #   { data: 'client_id' }
    #   { data: 'contractor_id' }
    # ]
  return

