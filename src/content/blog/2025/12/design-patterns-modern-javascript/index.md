---
title: "Design Patterns in Modern JavaScript"
excerpt: "Exploring classic design patterns and their implementation in modern JavaScript and TypeScript."
featuredImage: "https://images.unsplash.com/photo-1627398242454-45a1465c2479?w=800"
publishedDate: 2025-12-28
readTime: 12
tags: ["JavaScript", "Design Patterns", "TypeScript"]
categories: ["Software Engineering"]
---

Design patterns are proven solutions to recurring software design problems. While originally documented for object-oriented languages, they translate well to modern JavaScript and TypeScript.

## The Observer Pattern

The observer pattern is fundamental to many JavaScript frameworks. It allows objects to subscribe to events and react when they occur.

```typescript
class EventEmitter<T> {
  private listeners = new Map<string, ((data: T) => void)[]>();

  on(event: string, listener: (data: T) => void) {
    const existing = this.listeners.get(event) ?? [];
    this.listeners.set(event, [...existing, listener]);
  }

  emit(event: string, data: T) {
    this.listeners.get(event)?.forEach(listener => listener(data));
  }
}
```

## The Module Pattern

ES Modules bring the module pattern natively to JavaScript, enabling encapsulation and clear public APIs.

## The Factory Pattern

Factories create objects without specifying their exact class, making them ideal for creating objects whose types need to be determined at runtime.

```typescript
interface Shape {
  area(): number;
}

function createShape(type: 'circle', radius: number): Shape;
function createShape(type: 'rectangle', width: number, height: number): Shape;
function createShape(type: string, ...args: number[]): Shape {
  switch (type) {
    case 'circle': return { area: () => Math.PI * args[0] ** 2 };
    case 'rectangle': return { area: () => args[0] * args[1] };
    default: throw new Error(`Unknown shape: ${type}`);
  }
}
```

## Conclusion

Understanding classic design patterns helps you communicate solutions clearly and build more maintainable systems. JavaScript's flexibility makes implementing these patterns both easy and expressive.
