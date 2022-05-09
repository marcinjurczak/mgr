import React, { Component } from "react";

class Weather extends Component {
  constructor() {
    super();

    this.state = {
      desc: "",
      temp: 0,
    };
  }

  componentDidMount() {
    fetch(
      "https://api.openweathermap.org/data/2.5/weather?appid=ad058b50a02f29f63724fade627da689&q=Gdansk&units=metric"
    )
      .then((response) => response.json())
      .then((data) =>
        this.setState({
          desc: data.weather[0].description,
          temp: data.main.temp.toFixed(0),
        })
      );
  }

  render() {
    return (
      <div class="row">
        <div id="weather-description" class="inline">
          {" "}
          {this.state.desc}{" "}
        </div>
        <div class="inline">&nbsp;|&nbsp;</div>
        <div id="temp" class="inline">
          {" "}
          {this.state.temp} °C{" "}
        </div>
      </div>
    );
  }
}

export default Weather;
