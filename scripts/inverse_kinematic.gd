extends Object

class_name InverseKinematic

var theta_array
var a_array
var d_array
var alpha_array

func calculate2(position, rotation):
	var R_fi = [[cos(rotation.z), -sin(rotation.z), 0], 
	[sin(rotation.z), cos(rotation.z), 0], 
	[0, 0, 1]]
	var R_theta = [[cos(rotation.y), 0, sin(rotation.y)], 
	[0, 1, 0], 
	[-sin(rotation.y), 0, cos(rotation.y)]]
	var R_amega = [[cos(rotation.x), -sin(rotation.x), 0], 
	[sin(rotation.x), cos(rotation.x), 0], 
	[0, 0, 1]]
	
	var R_yx = multMat(R_theta, R_amega)
	var R_0_6 = multMat(R_yx, R_fi)
	
	var x_0_4 = position.x - d_array[5]*R_0_6[0][2]
	var y_0_4 = position.y - d_array[5]*R_0_6[1][2]
	var z_0_4 = position.z - d_array[5]*R_0_6[2][2]
	
	var b = z_0_4 - d_array[0]
	var c = sqrt(pow(x_0_4, 2)+pow(y_0_4, 2))
	
	var alpha_1 = atan2(y_0_4, x_0_4)
	var cos_alpha_3 = (pow(b, 2) + pow(c, 2) - pow(a_array[1], 2) - pow(d_array[3], 2)) / (2*a_array[1]*d_array[3])
	var sin_alpha_3 = sqrt(abs(1-pow(cos_alpha_3, 2)))
	var alpha_3 = atan(cos_alpha_3 / sin_alpha_3)
	var alpha_2 = atan(c / b) + atan((a_array[1] + d_array[3] * cos(alpha_3)) / (d_array[3]*sin(alpha_3)))
	
	return null
	#return [q1, q2, q3, q4, q5, q6]

func calculate1(position, R06, R03):
	var R06Z = multMat(R06, [[0], [0], [1]])
	var p04 = position - d_array[5] * Vector3(R06Z[0][0], R06Z[1][0], R06Z[2][0])
	var p14 = Vector3(p04.x, p04.y, p04.z - d_array[0])
	
	var a = sqrt(pow(p14.x, 2) + pow(p14.y, 2) + pow(p14.z, 2))
	var b = p04.z - d_array[0]
	var c = sqrt(pow(p04.x, 2) + pow(p04.y, 2))
	
	var cos_theta3 = (pow(b, 2) + pow(c, 2) - pow(a_array[1], 2) - pow(d_array[3], 2)) / (2*a_array[1]*d_array[3])
	#var theta3 = atan2zero(cos_theta3, sqrt(1-pow(cos_theta3, 2)))
	var theta3 = atan2zero(sqrt(1-pow(cos_theta3, 2)), cos_theta3)
	if (cos_theta3 == 1): theta3 = 0.001
	if (cos_theta3 == -1): theta3 = PI - 0.001
	var theta2 = atan2zero(b, c) - atan2zero(d_array[3]*sin(theta3), a_array[1]+d_array[3]*cos(theta3))
	#var theta2 = atan2zero(c, b) - atan2zero(a_array[1]+d_array[3]*sin(theta3), d_array[3]*cos(theta3))
	var theta1 = atan2zero(p04.y, p04.x)
	theta3 = atan2zero(cos_theta3, sqrt(1-pow(cos_theta3, 2)))
	
	#rotation
	var R36 = multMat(transpose(R03), R06)
	
	var q4 = atan2zero(sqrt(1-pow(R36[2][2], 2)), R36[2][2])
	var q5 = atan2zero(R36[0][2], R36[1][2])
	var q6 = atan2zero(-R36[2][0], R36[2][1])
	
	return [theta1, theta2, theta3, q4, q5, q6]

func _init(aArray, dArray, alphaArray):
	a_array = aArray
	d_array = dArray
	alpha_array = alphaArray

func multMat(m1, m2):
	var s=0     #сумма
	var t=[]    #временная матрица
	var m3=[] # конечная матрица
	if len(m2)!=len(m1[0]):
		pass     
	else:
		var r1=len(m1) #количество строк в первой матрице
		var c1=len(m1[0]) #Количество столбцов в 1   
		var r2=c1           #и строк во 2ой матрице
		var c2=len(m2[0])  # количество столбцов во 2ой матрице
		for z in range(0,r1):
			for j in range(0,c2):
				for i in range(0,c1):
					s=s+m1[z][i]*m2[i][j]
				t.append(s)
				s=0
			m3.append(t)
			t=[]           
	return m3
func transpose(matrix):
	var res=[]
	var n=len(matrix)
	var m=len(matrix[0])
	for j in range(m):
		var tmp=[]
		for i in range(n):
			tmp=tmp+[matrix[i][j]]
		res=res+[tmp]
	return res

#========================================================
func atan2zero(y, x):
	if(y < 0.01 and y > -0.01):
		y = 0
	if(x < 0.01 and x > -0.01):
		x = 0
	return atan2(y, x)
