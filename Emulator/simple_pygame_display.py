import pygame
import random

# Initialize Pygame
pygame.init()

# Constants
WIDTH, HEIGHT = 16, 16
PIXEL_SIZE = 30
SCREEN_SIZE = (WIDTH * PIXEL_SIZE, HEIGHT * PIXEL_SIZE)

# Set up the display
screen = pygame.display.set_mode(SCREEN_SIZE)
pygame.display.set_caption("16x16 Single-Byte Color Display")

# Create a 2D list to represent our 16x16 grid
grid = [[0 for _ in range(WIDTH)] for _ in range(HEIGHT)]

def update_grid():
    # Update each cell with a random color (0-255)
    for y in range(HEIGHT):
        for x in range(WIDTH):
            grid[y][x] = random.randint(0, 255)

def draw_grid():
    for y in range(HEIGHT):
        for x in range(WIDTH):
            color = grid[y][x]
            pygame.draw.rect(screen, (color, color, color), 
                             (x * PIXEL_SIZE, y * PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE))

# Main game loop
running = True
clock = pygame.time.Clock()

while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    update_grid()
    screen.fill((0, 0, 0))  # Clear the screen
    draw_grid()
    pygame.display.flip()  # Update the display
    clock.tick(10)  # Limit to 10 frames per second

pygame.quit()