export function increment() {
  return { type: 'INCREMENT' };
}

export function decrement() {
  return { type: 'DECREMENT' };
}

export function reset(n) {
  return { type: 'RESET', n };
}
