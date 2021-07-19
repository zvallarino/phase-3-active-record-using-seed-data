describe "seeds.rb" do
  it "creates 50 records in the games table" do
    expect { load "db/seeds.rb" }.to change(Game, :count).by(50)
  end
end
