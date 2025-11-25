"""
Nand2Tetris IDE - Command Executor
Executes a chain of commands in sequence, passing output from one to the next
"""


class CommandExecutor:
    """Executor for chaining multiple commands together"""
    
    def __init__(self, commands):
        """
        Initialize executor with a list of commands
        
        Args:
            commands: List of Command objects to execute in sequence
        """
        self.commands = commands
    
    def execute(self, input_data):
        """
        Execute all commands in sequence
        
        Args:
            input_data: Initial input data
            
        Returns:
            Final output after all commands have been executed
        """
        data = input_data
        for command in self.commands:
            data = command.execute(data)
        return data
