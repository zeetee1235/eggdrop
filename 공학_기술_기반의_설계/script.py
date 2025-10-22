import FreeCAD, Part, Draft
import math

doc = FreeCAD.newDocument("EggDrop")

# 정사면체 꼭짓점 좌표 (단위: mm)
a = 80  # 변 길이
h = math.sqrt(2/3) * a
vertices = [
    FreeCAD.Vector(0, 0, 0),
    FreeCAD.Vector(a, 0, 0),
    FreeCAD.Vector(a/2, math.sqrt(3)/2*a, 0),
    FreeCAD.Vector(a/2, math.sqrt(3)/6*a, h)
]

# 모서리 연결 (봉으로 표현)
rod_radius = 2
for i in range(len(vertices)):
    for j in range(i+1, len(vertices)):
        p1, p2 = vertices[i], vertices[j]
        # 중심부로 직접 향하지 않도록, 막대를 약간 바깥쪽으로만 생성
        vec = p2 - p1
        length = vec.Length
        direction = vec.normalize()
        # 양 끝에서 약간 안쪽으로 잘라내기
        offset = 3
        start = p1 + direction*offset
        end = p2 - direction*offset
        cyl = Part.makeCylinder(rod_radius, (end-start).Length, start, direction)
        Part.show(cyl)

# 각 변의 바깥쪽에 3.5배 길이의 봉 추가
outer_rod_radius = rod_radius  # 같은 굵기
extension_factor = 3.5

for i in range(len(vertices)):
    for j in range(i+1, len(vertices)):
        p1, p2 = vertices[i], vertices[j]
        vec = p2 - p1
        edge_length = vec.Length
        direction = vec.normalize()
        
        # 3.5배 길이의 봉을 변의 중심에 배치
        rod_length = edge_length * extension_factor
        
        # 변의 중심점
        edge_center = (p1 + p2) / 2
        
        # 봉의 시작점과 끝점 (변의 중심을 기준으로 양쪽으로 확장)
        rod_start = edge_center - direction * (rod_length / 2)
        rod_end = edge_center + direction * (rod_length / 2)
        
        # 바깥쪽 봉 생성
        outer_cyl = Part.makeCylinder(outer_rod_radius, rod_length, rod_start, direction)
        Part.show(outer_cyl)

# 각 변의 중점과 반대편 꼭짓점을 잇는 선 추가
support_rod_radius = 1.5  # 지지대 봉의 반지름 (약간 더 가늘게)

for i in range(len(vertices)):
    for j in range(i+1, len(vertices)):
        p1, p2 = vertices[i], vertices[j]
        
        # 변의 중점
        midpoint = (p1 + p2) / 2
        
        # 이 변에 포함되지 않은 나머지 두 꼭짓점 찾기
        opposite_vertices = [v for k, v in enumerate(vertices) if k != i and k != j]
        
        # 각 반대편 꼭짓점과 중점을 연결
        for opposite_vertex in opposite_vertices:
            vec = opposite_vertex - midpoint
            length = vec.Length
            direction = vec.normalize()
            
            # 중점에서 반대편 꼭짓점으로 선 그리기
            support_cyl = Part.makeCylinder(support_rod_radius, length, midpoint, direction)
            Part.show(support_cyl)

# 바깥쪽 봉의 끝점 정보 저장
tape_width = 30  # 테이프 폭
outer_rods_info = []

for i in range(len(vertices)):
    for j in range(i+1, len(vertices)):
        p1, p2 = vertices[i], vertices[j]
        vec = p2 - p1
        edge_length = vec.Length
        direction = vec.normalize()
        
        rod_length = edge_length * extension_factor
        edge_center = (p1 + p2) / 2
        
        # 봉의 양 끝점
        rod_start = edge_center - direction * (rod_length / 2)
        rod_end = edge_center + direction * (rod_length / 2)
        
        # 끝에서 안쪽으로 40mm 들어온 점
        inner_from_start = rod_start + direction * tape_width
        inner_from_end = rod_end - direction * tape_width
        
        outer_rods_info.append({
            'vertices': (i, j),
            'rod_start': rod_start,
            'rod_end': rod_end,
            'inner_start': inner_from_start,
            'inner_end': inner_from_end,
            'direction': direction
        })

# 정사면체의 각 면에서 인접한 변들끼리 사다리꼴 연결
faces_vertices = [
    [0, 1, 2],  # 아래 면
    [0, 1, 3],  # 옆면 1
    [1, 2, 3],  # 옆면 2
    [0, 2, 3]   # 옆면 3
]

created_faces = set()

for face_verts in faces_vertices:
    # 이 면의 3개 변 찾기
    face_edges = []
    for idx in range(3):
        v1 = face_verts[idx]
        v2 = face_verts[(idx + 1) % 3]
        edge_key = tuple(sorted([v1, v2]))
        
        # outer_rods_info에서 해당 변 찾기
        for rod_info in outer_rods_info:
            if tuple(sorted(rod_info['vertices'])) == edge_key:
                face_edges.append(rod_info)
                break
    
    # 이 면의 3개 변에 대해 인접한 변들끼리 사다리꼴 연결
    for idx in range(3):
        rod1 = face_edges[idx]
        rod2 = face_edges[(idx + 1) % 3]
        
        # 두 변이 공유하는 꼭짓점 찾기
        v1_set = set(rod1['vertices'])
        v2_set = set(rod2['vertices'])
        shared = v1_set & v2_set
        
        if len(shared) == 1:
            shared_vertex = list(shared)[0]
            
            # rod1에서 공유 꼭짓점 쪽 끝점 찾기
            v1_vertices = rod1['vertices']
            if v1_vertices[0] == shared_vertex:
                rod1_outer = rod1['rod_start']
                rod1_inner = rod1['inner_start']
            else:
                rod1_outer = rod1['rod_end']
                rod1_inner = rod1['inner_end']
            
            # rod2에서 공유 꼭짓점 쪽 끝점 찾기
            v2_vertices = rod2['vertices']
            if v2_vertices[0] == shared_vertex:
                rod2_outer = rod2['rod_start']
                rod2_inner = rod2['inner_start']
            else:
                rod2_outer = rod2['rod_end']
                rod2_inner = rod2['inner_end']
            
            # 사다리꼴 생성: 두 바깥 끝점과 두 안쪽 40mm 점
            # 중복 생성 방지
            face_key = tuple(sorted([
                (rod1_outer.x, rod1_outer.y, rod1_outer.z),
                (rod2_outer.x, rod2_outer.y, rod2_outer.z)
            ]))
            
            if face_key not in created_faces:
                created_faces.add(face_key)
                try:
                    line1 = Part.LineSegment(rod1_outer, rod2_outer)
                    line2 = Part.LineSegment(rod2_outer, rod2_inner)
                    line3 = Part.LineSegment(rod2_inner, rod1_inner)
                    line4 = Part.LineSegment(rod1_inner, rod1_outer)
                    
                    wire = Part.Wire([line1.toShape(), line2.toShape(), line3.toShape(), line4.toShape()])
                    face_obj = Part.Face(wire)
                    Part.show(face_obj)
                    
                    print(f"Created trapezoid face at shared vertex {shared_vertex}")
                except Exception as e:
                    print(f"Error creating trapezoid: {e}")

# 반대쪽 끝점들도 연결 (각 면의 반대편 끝점들끼리)
for face_verts in faces_vertices:
    # 이 면의 3개 변 찾기
    face_edges = []
    for idx in range(3):
        v1 = face_verts[idx]
        v2 = face_verts[(idx + 1) % 3]
        edge_key = tuple(sorted([v1, v2]))
        
        # outer_rods_info에서 해당 변 찾기
        for rod_info in outer_rods_info:
            if tuple(sorted(rod_info['vertices'])) == edge_key:
                face_edges.append(rod_info)
                break
    
    # 이 면의 3개 변에 대해 반대편 끝점들끼리 연결
    for idx in range(3):
        rod1 = face_edges[idx]
        rod2 = face_edges[(idx + 1) % 3]
        
        # 두 변이 공유하는 꼭짓점 찾기
        v1_set = set(rod1['vertices'])
        v2_set = set(rod2['vertices'])
        shared = v1_set & v2_set
        
        if len(shared) == 1:
            shared_vertex = list(shared)[0]
            
            # rod1에서 공유하지 않는 쪽 끝점 찾기 (반대편)
            v1_vertices = rod1['vertices']
            if v1_vertices[0] == shared_vertex:
                rod1_far_outer = rod1['rod_end']
                rod1_far_inner = rod1['inner_end']
            else:
                rod1_far_outer = rod1['rod_start']
                rod1_far_inner = rod1['inner_start']
            
            # rod2에서 공유하지 않는 쪽 끝점 찾기 (반대편)
            v2_vertices = rod2['vertices']
            if v2_vertices[0] == shared_vertex:
                rod2_far_outer = rod2['rod_end']
                rod2_far_inner = rod2['inner_end']
            else:
                rod2_far_outer = rod2['rod_start']
                rod2_far_inner = rod2['inner_start']
            
            # 반대편 끝점들끼리 사다리꼴 생성
            face_key = tuple(sorted([
                (rod1_far_outer.x, rod1_far_outer.y, rod1_far_outer.z),
                (rod2_far_outer.x, rod2_far_outer.y, rod2_far_outer.z)
            ]))
            
            if face_key not in created_faces:
                created_faces.add(face_key)
                try:
                    line1 = Part.LineSegment(rod1_far_outer, rod2_far_outer)
                    line2 = Part.LineSegment(rod2_far_outer, rod2_far_inner)
                    line3 = Part.LineSegment(rod2_far_inner, rod1_far_inner)
                    line4 = Part.LineSegment(rod1_far_inner, rod1_far_outer)
                    
                    wire = Part.Wire([line1.toShape(), line2.toShape(), line3.toShape(), line4.toShape()])
                    face_obj = Part.Face(wire)
                    Part.show(face_obj)
                    
                    print(f"Created trapezoid face at opposite ends")
                except Exception as e:
                    print(f"Error creating opposite trapezoid: {e}")

doc.recompute()

