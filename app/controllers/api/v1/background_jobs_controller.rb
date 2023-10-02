class Api::V1::BackgroundJobsController < Api::V1::ApplicationController
  def index
    # BackGroundJobの一覧を取得する
    status = params[:status]
    job_type = params[:job_type]
    page = params[:page].present? ? params[:page] : 1
    per_page = params[:per_page].present? ? params[:per_page] : 10

    @background_jobs = BackgroundJob.search(status: status, job_type: job_type, page: page, per: per_page)
  end

  def show
    # BackGroundJobの詳細を取得する
    @background_job = BackgroundJob.find(params[:id])
  end
end
