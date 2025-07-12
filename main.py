import random
import os

HISTORY_FILE = "history.txt"

class RouletteAnalyzer:
    """
    A class to analyze roulette numbers and suggest the next possible numbers.
    """
    def __init__(self):
        self.history = self._load_history()
        self.all_numbers = set(range(37))

    def _load_history(self) -> list[int]:
        """Loads the history from a file."""
        if not os.path.exists(HISTORY_FILE):
            return []
        with open(HISTORY_FILE, 'r') as f:
            return [int(line.strip()) for line in f]

    def _save_history(self):
        """Saves the current history to a file."""
        with open(HISTORY_FILE, 'w') as f:
            for number in self.history:
                f.write(f"{number}\n")

    def add_number(self, number: int):
        """Adds a new number to the history and saves it."""
        if 0 <= number <= 36:
            self.history.append(number)
            self._save_history()
        else:
            print("Invalid number. Please enter a number between 0 and 36.")

    def get_predictions(self) -> list[int]:
        """
        Returns a list of 25 suggested numbers based on the history,
        with 0 always included and 2 numbers from each street.
        """
        predictions = [0]
        streets = [
            [1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12],
            [13, 14, 15], [16, 17, 18], [19, 20, 21], [22, 23, 24],
            [25, 26, 27], [28, 29, 30], [31, 32, 33], [34, 35, 36]
        ]

        counts = {num: 0 for num in self.all_numbers}
        for num in self.history:
            if num in counts:
                counts[num] += 1

        for street in streets:
            # Sort numbers in the street by frequency (coldest first)
            sorted_street = sorted(street, key=lambda x: counts[x])
            # Add the two coldest numbers from the street to predictions
            predictions.extend(sorted_street[:2])

        return predictions

def main():
    """
    Main function to run the roulette prediction system.
    """
    analyzer = RouletteAnalyzer()
    print("--- Roulette Prediction System ---")
    print(f"Loaded {len(analyzer.history)} numbers from previous sessions.")
    print("Enter the winning number after each spin.")
    print("Type 'exit' to quit or 'reset' to clear the history.")

    # Generate and display initial predictions
    last_predictions = analyzer.get_predictions()
    print(f"\nInitial recommended numbers to bet on: {last_predictions}")
    if analyzer.history:
        print(f"Current History: {analyzer.history}\n")


    while True:
        try:
            user_input = input("Enter the last winning number (0-36): ")
            if user_input.lower() == 'exit':
                break
            if user_input.lower() == 'reset':
                if os.path.exists(HISTORY_FILE):
                    os.remove(HISTORY_FILE)
                analyzer.history = []
                print("\nHistory has been cleared.")
                last_predictions = analyzer.get_predictions()
                print(f"\nNew initial predictions: {last_predictions}\n")
                continue

            number = int(user_input)
            
            # Check for hit or miss
            if number in last_predictions:
                print("\n>>> HIT! <<<")
            else:
                print("\n>>> MISS. <<<")

            analyzer.add_number(number)

            # Generate new predictions for the next round
            predictions = analyzer.get_predictions()
            last_predictions = predictions # update for the next iteration
            
            print(f"\nNext recommended numbers to bet on: {predictions}")
            print(f"Current History: {analyzer.history}\n")

        except ValueError:
            print("Invalid input. Please enter a number or type 'exit' or 'reset'.")
        except Exception as e:
            print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()