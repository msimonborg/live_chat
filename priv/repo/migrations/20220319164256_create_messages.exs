defmodule LiveChat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :text
      add :created_by, :string
      add :room_id, references(:rooms, on_delete: :delete_all)

      timestamps()
    end

    create index(:messages, [:room_id])
  end
end
