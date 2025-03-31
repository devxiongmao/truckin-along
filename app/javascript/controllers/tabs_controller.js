import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tab", "content"];

  connect() {
    if (this.tabTargets.length > 0) {
      // Set the first tab as active by default
      this.showTab({ currentTarget: this.tabTargets[0] });
    }
  }

  showTab(event) {
    // Get the tab id from the data-tab attribute
    const selectedTab = event.currentTarget.dataset.tab;

    // Remove active class from all tabs and contents
    this.tabTargets.forEach(tab => tab.classList.remove("active"));
    this.contentTargets.forEach(content => content.classList.remove("active"));

    // Add active class to clicked tab
    event.currentTarget.classList.add("active");

    // Find and activate the corresponding content
    const selectedContent = this.contentTargets.find(content => content.id === selectedTab);
    if (selectedContent) {
      selectedContent.classList.add("active");
    } else {
      console.error(`No matching content for tab: ${selectedTab}`);
    }
  }
}