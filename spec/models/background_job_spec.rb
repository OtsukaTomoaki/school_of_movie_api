require 'rails_helper'

RSpec.describe BackgroundJob, type: :model do
  describe 'validations' do
    subject { build(:background_job) }

    it { should validate_presence_of(:job_type) }
    it { should validate_presence_of(:query) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[pending processing complete error]) }
    it { should validate_presence_of(:external_api_limit) }
    it { should validate_numericality_of(:external_api_limit).only_integer.is_greater_than(0) }
    it { should validate_presence_of(:external_api_requests_count) }
    it { should validate_numericality_of(:external_api_requests_count).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe '.find_or_create_job' do
    let(:job_type) { 'movie_search' }
    let(:query) { 'Inception' }

    context 'when the job does not exist' do
      it 'creates a new job' do
        expect { BackgroundJob.find_or_create_job(job_type, query) }.to change { BackgroundJob.count }.by(1)

        job = BackgroundJob.last
        expect(job.job_type).to eq(job_type)
        expect(job.query).to eq(query)
        expect(job.status).to eq('pending')
        expect(job.external_api_limit).to eq(10)
      end
    end

    context 'when the job already exists' do
      let!(:existing_job) { create(:background_job, job_type: job_type, query: query) }

      it 'does not create a new job' do
        expect { BackgroundJob.find_or_create_job(job_type, query) }.not_to change { BackgroundJob.count }
      end

      it 'returns the existing job' do
        job = BackgroundJob.find_or_create_job(job_type, query)
        expect(job).to eq(existing_job)
      end
    end
  end
end