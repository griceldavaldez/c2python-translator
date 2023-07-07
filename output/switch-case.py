def main():
	operator = '+'
	operand1 = 10
	operand2 = 5
	
	match operator:
		case '+':
			result = operand1+operand2
			print("La suma es: %d\n" % (result))
		
		case '-':
			result = operand1-operand2
			print("La resta es: %d\n" % (result))
		
		case '*':
			result = operand1*operand2
			print("La multiplicación es: %d\n" % (result))
		
		case '/':
			result = operand1/operand2
			print("La división es: %d\n" % (result))
		
		case _ :
	 		print("Operador no válido.\n")
		
		
	return 0
	
if __name__ == '__main__':
	main()
