
from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    return LaunchDescription([
        Node(
            package='control',
            executable='control',
            namespace='/',
            name='control'
        ),
        Node(
            package='rviz2',
            executable='rviz2',
            output='screen',
            namespace='/',
            name='rviz2',
            respawn=True,
            arguments=['-d', '/home/tentone/Git/tello-slam/workspace/src/rviz.rviz']
        ),
        Node(
            package='tello',
            executable='tello',
            output='screen',
            namespace='/',
            name='tello',
            parameters=[
                {'connect_timeout': 10.0},
                {'tello_ip': '192.168.10.1'},
                {'tf_base': 'map'},
                {'tf_drone': 'drone'}
            ],
            remappings=[],
            respawn=True
        )
        # Node(
        #     package='tf2_ros',
        #     executable='static_transform_publisher',
        #     namespace='/',
        #     name='tf',
        #     arguments=['1', '0', '0', '0', '0', '0', '1', 'map', 'drone'],
        #     respawn=True
        # )
    ])