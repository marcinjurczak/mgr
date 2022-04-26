import React, { Component } from 'react';
import Clock from './Clock';
import Weather from './Weather'
import Search from './Search'
import Bookmarks from './Bookmarks'
import "./styles.css"

export default class App extends Component {

    constructor() {
        super();

        this.state = {
            title: 'Startpage'
        };
    }

    render() {
        return (
            <div class="container">
                <div id="clock">
                    <Clock/>
                </div>
                <div class="weather-container">
                    <Weather/>
                </div>
                <div id="search">
                   <Search/>
                </div>
                <div id="bookmark-container">
                    <Bookmarks/>
                </div>
            </div>
        );
    }
}

