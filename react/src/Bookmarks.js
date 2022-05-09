import React, { Component } from "react";
import bookmarks from "./data.js";

class Bookmarks extends Component {
  constructor() {
    super();

    this.state = {
      bookmarks: bookmarks,
      title: "Bookmarks",
    };
  }

  render() {
    const listBookmarks = this.state.bookmarks.map((b) => (
      <li class="bookmark">
        <a class="bookmark" href={b.url}>
          {b.name}
        </a>
      </li>
    ));
    return (
      <div class="bookmark-set">
        <div class="bookmark-title">{this.state.title}</div>
        <div class="bookmark-inner-container">
          <ul>{listBookmarks}</ul>
        </div>
      </div>
    );
  }
}

export default Bookmarks;
