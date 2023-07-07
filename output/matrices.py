def main():
	mat_1 = [[1, 4, 6], [2, 0, 5], [8, 3, 3]]
	mat_2 = [[None] * 3 for i in range(3)] 
				
	for i in range(0,3):		
		for j in range(0,3):			
			mat_2[i][j] = i+j
			
		
	total = 0
	for i in range(0,3):		
		for j in range(0,3):			
			total += mat_1[i][j]+mat_2[i][j]
			
		
	print("Total: %d\n" % (total))
	return 0
	
if __name__ == '__main__':
	main()
