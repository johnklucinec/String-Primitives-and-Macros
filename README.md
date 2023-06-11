## Description of the Program
*For some reason, GitHub likes to break the formatting on my comments. I guess "tab" is different in my editor (Visual Studio 2019) and on GitHub.*
*Code is in the **Proj6_klucinej.asm** file*

This program, titled "String Primitives and Macros" (Proj6_klucinej.asm), is an assembly project developed by John Klucinec for CS271 Section 400 at Oregon State University. The program is designed to practice low-level I/O procedures by taking a series of signed decimal integers from the user, storing them in an array, and then calculating and displaying their sum and truncated average. The program also includes error handling for invalid input and ensures that the input numbers are within the range of 32-bit signed integers.
Overview of the Code

### The program is organized into several sections:

1. Macro section: This section contains two macros, mGetString and mDisplayString, which are used for getting input from the user and displaying strings, respectively stackoverflow.com.

2. Constants: The program defines constants for array size (ARRAYSIZE), buffer size (BUFFER_SIZE), and the lower (LO) and upper (HI) limits of valid 32-bit signed integers.

3. Data section: This section contains strings for prompts, error messages, and result messages, as well as variables and arrays used in the program, such as the input array, sum, and average.

4. Main procedure: The main procedure calls various sub-procedures to display an introduction, read input values, display the input values, find the sum, find the average, and display a farewell message.

5. ReadVal procedure: This procedure reads a signed decimal integer from the user's input, validates the input, and stores the result in the convSTR variable. It uses the mGetString macro to get input from the user and loops through each character, checking for a valid signed integer and converting it to a number. If the input is invalid or out of range, the program displays an error message and prompts the user to try again.

6. Other sub-procedures: The program includes several other sub-procedures for displaying the input array, calculating the sum and average of the numbers, and displaying the results. These procedures make use of the mDisplayString macro and other functions from the Irvine32 library.

### Here's an example of how the program works:

1. The user is prompted to enter 10 signed decimal integers.
2. The program validates each input and stores it in an array.
3. Once all inputs are received, the program displays the list of entered numbers, their sum, and their truncated average.
4. The program ends with a farewell message.

        Program to practice designing low-level I/O procedures                  By: Johnny Klucinec

        Please provide 10 signed decimal integers.
        Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.

        Please enter an signed number: 156
        Please enter an signed number: 51d6fd
        ERROR: You did not enter an signed number or your number was too big.
        Please try again: 34
        Please enter an signed number: -186
        Please enter an signed number: 324545645323454
        ERROR: You did not enter an signed number or your number was too big.
        Please try again: -145
        Please enter an signed number: 16
        Please enter an signed number: +23
        Please enter an signed number: 51
        Please enter an signed number: 0
        Please enter an signed number: 56
        Please enter an signed number: 11

        You entered the following numbers:
        156, 34, -186, -145, 16, 23, 51, 0, 56, 11

        The sum of these numbers is: 16

        The truncated average is: 1

        Thanks for playing!

**This program serves as a template for developing assembly projects in CS271 and helps students practice designing low-level I/O procedures in assembly language.**
