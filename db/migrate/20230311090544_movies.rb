class Movies < ActiveRecord::Migration[7.0]
  def change
    create_table :movies, id: false do |t|
      t.string :id, limit: 36, null: false, primary_key: true
      t.string :the_movie_database_id, limit: 36, null: false, comment: 'tmdbで管理されているid'
      t.text :title, null: false, comment: 'タイトル'
      t.text :original_title, null: false, comment: '原題'
      t.text :overview, null: false, comment: '概要'
      t.string :poster_path, limit: 255, null: false, comment: 'ポスター画像パス'
      t.string :backdrop_path, limit: 255, null: false, comment: '背景画像パス'
      t.string :original_language, limit: 10, null: false, comment: '言語'
      t.boolean :adult, null: false, comment: '成人向け'
      t.decimal :vote_average, null: true, comment: '平均評価'
      t.integer :vote_count, null: true, comment: '評価数'
      t.datetime :release_date, null: false, comment: '公開日'
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    add_index :movies, [:the_movie_database_id], unique: true
  end
end
