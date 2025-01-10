// This code goes in heroes.component.ts
import { Component, EventEmitter, Output } from '@angular/core';
import { CommonModule } from '@angular/common';

interface Hero {
  id: number;
  name: string;
  themeClass: string;
}

@Component({
  selector: 'app-heroes',
  templateUrl: './heroes.component.html',
  styleUrls: ['./heroes.component.css'],
  standalone: true,
  imports: [CommonModule]
})
export class HeroesComponent {
  heroes: Hero[] = [
    { id: 1, name: "Spider-Man", themeClass: 'hero-spider-man' },
    { id: 2, name: "Iron Man", themeClass: 'hero-iron-man' },
    { id: 3, name: "Thor", themeClass: 'hero-thor' },
    { id: 4, name: "Hulk", themeClass: 'hero-hulk' }
  ];

  selectedHero?: Hero;

  @Output() themeChange = new EventEmitter<string>(); // Ensure this is declared to emit string type

  onSelect(hero: Hero): void {
    this.selectedHero = hero;
    this.themeChange.emit(hero.themeClass); // Emit the hero's theme class directly
  }
}
