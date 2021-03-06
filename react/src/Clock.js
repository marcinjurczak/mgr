import React, { Component } from "react";

class Clock extends Component {
  constructor() {
    super();

    this.state = {
      date: new Date(),
    };
  }

  currentTime() {
    this.setState({ date: new Date() });
  }

  componentDidMount() {
    setInterval(() => this.currentTime(), 1000);
  }

  render() {
    return (
        <div>
        <div id="clock">{this.state.date.toLocaleTimeString()}</div>
        <div id="date">{this.state.date.toLocaleDateString()}</div>
        </div>
    );
  }
}

export default Clock;
