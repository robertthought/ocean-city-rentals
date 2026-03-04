class Admin::RentalRequestsController < Admin::BaseController
  def index
    @rental_requests = RentalRequest.recent
    @rental_requests = @rental_requests.uncontacted if params[:filter] == "uncontacted"
  end

  def show
    @rental_request = RentalRequest.find(params[:id])
  end

  def mark_contacted
    @rental_request = RentalRequest.find(params[:id])
    @rental_request.mark_contacted!
    redirect_to admin_rental_requests_path, notice: "Marked as contacted"
  end

  def export
    @rental_requests = RentalRequest.recent

    respond_to do |format|
      format.csv do
        headers["Content-Disposition"] = "attachment; filename=rental_requests_#{Date.today}.csv"
        headers["Content-Type"] = "text/csv"
      end
    end
  end
end
