# typed: false

require "rails_helper"

# uses page.driver.post because we're not running a full js engine,
# so the call can't just be click_on('delete'), etc.

RSpec.feature "Stories" do
  let(:user) { create(:user) }
  let(:story) { create(:story, user: user) }
  let!(:inactive_user) { create(:user, :inactive) }
  let!(:story_without_user) { create(:story) }

  before(:each) { stub_login_as user }

  feature "disowning stories" do
    scenario "disowning a story" do
      page.driver.post "/stories/#{story.short_id}/disown"
      story.reload
      expect(story.user).to eq(inactive_user)

      visit "/s/#{story.short_id}"
      expect(page).to have_content("inactive-user")
    end

    scenario "shows disown in story page" do
      visit "/s/#{story.short_id}"
      expect(page).to have_link("disown")
    end

    scenario "does not show disown in active stories page" do
      visit "/active"
      expect(page).not_to have_link("disown")
      expect(page).to have_content(user.username)
    end

    scenario "trying to disown not owned stories" do
      visit "/s/#{story_without_user.short_id}"
      expect(page).not_to have_link("disown")

      page.driver.post "/stories/#{story_without_user.short_id}/disown"
      story.reload
      expect(story.user).to eq(user)
    end
  end
end
