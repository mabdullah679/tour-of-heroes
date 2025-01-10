// This code goes in app.component.ts
import { Component } from '@angular/core';
import { HeroesComponent } from './heroes/heroes.component'; // Ensure this path is correct

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
  imports: [HeroesComponent] // Include HeroesComponent here to ensure it is recognized
})
export class AppComponent {
  currentTheme: string = '';

  // Correct handling of the event type if it's guaranteed to be a string
  onThemeChange(theme: string) {
    this.currentTheme = theme;
    document.body.className = theme;  // Apply the class to the body
  }
}
