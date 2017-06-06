require 'rails_helper'

RSpec.feature "As an admin" do
  it "sees all orders separated by status" do
    admin = create(:user, role: 1)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
    order1 = create(:order, status: 0)
    order6 = create(:order, status: 0)
    order2 = create(:order, status: 1)
    order3 = create(:order, status: 2)
    order4 = create(:order, status: 3)
    order5 = create(:order, status: 3)

    visit admin_dashboard_index_path
    page.should have_content("Ordered (2)")
    page.should have_content("Paid (1)")
    page.should have_content("Cancelled (1)")
    page.should have_content("Completed (2)")

    click_on "Ordered (2)"
    within('.orders-table.ordered') do
      page.should have_content("Ordered")
      page.should have_content("#{order1.id}")
      page.should have_content("#{order6.id}")
      page.should have_link("Cancel")
      page.should have_link("Paid")
    end

    click_on "Paid (1)"
    within('.orders-table.paid') do
      page.should have_content("Paid")
      page.should have_link("#{order2.id}", href:admin_order_path(order2))
      page.should have_link("Cancel")
      page.should have_link("Completed")
    end

    click_on "Cancelled (1)"
    within('.orders-table.cancelled') do
      page.should have_content("Cancelled")
      page.should have_link("#{order3.id}", href:admin_order_path(order3))
    end

    click_on "Completed (2)"
    within('.orders-table.completed') do
      page.should have_content("Completed")
      page.should have_link("#{order4.id}", href:admin_order_path(order4))
      page.should have_link("#{order5.id}", href:admin_order_path(order5))
    end
  end

  it "can change statuses" do
    admin = create(:user, role: 1)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
    order1 = create(:order, status: 0)

    visit admin_dashboard_index_path
    
    click_on "Ordered (1)"
    within('.orders-table.ordered') do
      click_on "Paid"
    end

    click_on "Paid (1)"
    within('.orders-table.paid') do
      expect(page).to have_content(order1.user.full_name)
      click_on "Cancel"
    end

    click_on "Cancelled (1)"
    within('.orders-table.cancelled') do
      expect(page).to have_content(order1.user.full_name)
    end
    

    order2 = create(:order, status: 0)
    visit admin_dashboard_index_path
    
    click_on "Ordered (1)"
    within('.orders-table.ordered') do
      click_on "Paid"
    end

    click_on "Paid (1)"
    within('.orders-table.paid') do
      expect(page).to have_content(order2.user.full_name)
      click_on "Completed"
    end

    click_on "Completed (1)"
    within('.orders-table.completed') do
      expect(page).to have_content(order2.user.full_name)
    end
  end
end
